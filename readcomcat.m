% readcomcat - Read CSV files as generated by ComCat search API.
%   data = readsmgrid(csvfile);
%   Input:
%    - csvfile is a valid filename for a ComCat CSV file.
%   Output:
%    - data is a Matlab structure array, with each element containing fields:
%      - time Matlab datenum of origin time.
%      - lat  Latitude of origin.
%      - lon  Longitude of origin.
%      - depth Depth of origin.
%      - mag   Magnitude of origin.
%      - magtype Magnitude type (Mb, Ms, etc.)
%      - nst     Number of stations used to determine the solution.
%      - dmin    ??
%      - rms     Root mean square error of ??
%      - net     Contributing network of origin.
%      - id      Event id
%      - updated Matlab datenum Time of most recent origin update.
%      - place   String indicating location of epicenter.
%      - type    Usually earthquake, but may be mine collapse, mining explosion, etc.
function [data] = readcomcat(csvfile)
    TIMEFMT = 'yyyy-mm-ddTHH:MM:SS.FFF';
    data = struct([]);
    fid = fopen(csvfile);
    tline = fgetl(fid);
    tline = fgetl(fid);
    i = 1;
    while (ischar(tline))
        %need to deal with commas inside quotes of location string
        cidx = strfind(tline,'"');
        if rem(length(cidx),2)
            fprintf('Can''t parse line "%s".  Skipping.\n',tline);
            continue;
        end
        newtline = tline(1:cidx(1)-1); %get the first unquoted segment
        for i=1:length(cidx)-1
            qstart = cidx(i);
            qend = cidx(i+1);
            segment = tline(qstart:qend);
            segment = strrep(segment,',','#');
            newtline = [newtline segment];
        end
        newtline = [newtline tline(cidx(end)+1:end)];
        parts = regexpi(newtline,',','split');
        timestr = parts{1}(1:23);
        data(i).time = datenum(timestr,TIMEFMT);
        data(i).lat = str2double(parts{2});
        data(i).lon = str2double(parts{3});
        data(i).depth = str2double(parts{4});
        data(i).mag = str2double(parts{5});
        data(i).magtype = parts{6};
        data(i).nst = str2num(parts{7});
        data(i).gap = str2double(parts{8});
        data(i).dmin = str2double(parts{9});
        data(i).rms = str2double(parts{10});
        data(i).net = parts{11};
        data(i).id = parts{12};
        data(i).updated = datenum(parts{13}(1:23),TIMEFMT);
        data(i).place = strrep(strrep(parts{14},'#',','),'"','');
        data(i).type = parts{15};
        data(i) = data(i);
        i = i + 1;
        tline = fgetl(fid);
    end
    fclose(fid);
    
end